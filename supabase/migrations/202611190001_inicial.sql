-- Estoque Certo: dados isolados por conta. Execute uma única vez em projeto novo.
create table public.materials (
 id uuid primary key default gen_random_uuid(), owner_id uuid not null default auth.uid() references auth.users(id),
 name text not null check(length(trim(name)) > 0), description text not null default '', category text not null default '',
 unit text not null check(length(trim(unit)) > 0), quantity numeric(16,3) not null default 0 check(quantity >= 0 and quantity::text <> 'NaN'),
 minimum numeric(16,3) not null default 0 check(minimum >= 0 and minimum::text <> 'NaN'), location text not null default '', code text not null default '',
 replenishment_status text not null default 'pendente' check(replenishment_status in ('pendente','em cotação','compra planejada')),
 created_at timestamptz not null default now(), unique(id,owner_id)
);
create unique index materials_owner_code on public.materials(owner_id, lower(code)) where code <> '';
create index materials_owner_name on public.materials(owner_id,name);
create table public.suppliers (
 id uuid primary key default gen_random_uuid(), owner_id uuid not null default auth.uid() references auth.users(id),
 name text not null check(length(trim(name))>0), contact text not null default '', phone text not null default '', email text not null default '',
 created_at timestamptz not null default now(), unique(id,owner_id)
);
create index suppliers_owner_name on public.suppliers(owner_id,name);
create table public.offers (
 id uuid primary key default gen_random_uuid(), owner_id uuid not null default auth.uid() references auth.users(id),
 material_id uuid not null, supplier_id uuid not null, package_description text not null default '',
 quantity numeric(16,3) not null check(quantity > 0 and quantity::text <> 'NaN'), price numeric(16,2) not null check(price >= 0 and price::text <> 'NaN'),
 quoted_at date not null default current_date, created_at timestamptz not null default now(),
 foreign key(material_id,owner_id) references public.materials(id,owner_id) on delete restrict,
 foreign key(supplier_id,owner_id) references public.suppliers(id,owner_id) on delete restrict
);
create index offers_owner_material on public.offers(owner_id,material_id);
create index offers_owner_supplier on public.offers(owner_id,supplier_id);
create table public.movements (
 id uuid primary key default gen_random_uuid(), owner_id uuid not null default auth.uid() references auth.users(id),
 material_id uuid not null, kind text not null check(kind in ('entrada','saída')), quantity numeric(16,3) not null check(quantity > 0 and quantity::text <> 'NaN'),
 responsible text not null check(length(trim(responsible))>0), note text not null default '', created_at timestamptz not null default now(),
 foreign key(material_id,owner_id) references public.materials(id,owner_id) on delete restrict
);
create index movements_owner_created on public.movements(owner_id,created_at desc);
create index movements_owner_material on public.movements(owner_id,material_id);

alter table public.materials enable row level security;
alter table public.suppliers enable row level security;
alter table public.offers enable row level security;
alter table public.movements enable row level security;
create policy materials_select on public.materials for select to authenticated using (owner_id = (select auth.uid()));
create policy materials_insert on public.materials for insert to authenticated with check (owner_id = (select auth.uid()) and quantity = 0);
create policy materials_update on public.materials for update to authenticated using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy materials_delete on public.materials for delete to authenticated using (owner_id = (select auth.uid()) and quantity = 0);
create policy suppliers_all on public.suppliers for all to authenticated using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy offers_all on public.offers for all to authenticated using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy movements_read on public.movements for select to authenticated using (owner_id = (select auth.uid()));
revoke all on public.materials,public.suppliers,public.offers,public.movements from anon,authenticated;
grant select, delete on public.materials to authenticated;
grant insert (name,description,category,unit,minimum,location,code) on public.materials to authenticated;
grant update (name,description,category,unit,minimum,location,code,replenishment_status) on public.materials to authenticated;
grant select,insert,update,delete on public.suppliers,public.offers to authenticated;
grant select on public.movements to authenticated;

-- A linha do material é bloqueada até o commit, garantindo saldo consistente.
create function public.registrar_movimentacao(p_material uuid, p_kind text, p_quantity numeric, p_responsible text, p_note text default '') returns void
language plpgsql security definer set search_path = '' as $$
declare v_saldo numeric; v_uid uuid := auth.uid();
begin
 if v_uid is null then raise exception 'Autenticação necessária'; end if;
 if p_kind not in ('entrada','saída') or p_kind is null then raise exception 'Tipo inválido'; end if;
 if p_quantity is null or p_quantity <= 0 or p_quantity::text in ('NaN','Infinity','-Infinity') or round(p_quantity,3) <> p_quantity then raise exception 'Quantidade inválida'; end if;
 if p_responsible is null or length(trim(p_responsible)) = 0 then raise exception 'Informe o responsável'; end if;
 select quantity into v_saldo from public.materials where id=p_material and owner_id=v_uid for update;
 if not found then raise exception 'Material não encontrado'; end if;
 if p_kind='saída' and p_quantity>v_saldo then raise exception 'Quantidade maior que o estoque disponível'; end if;
 update public.materials set quantity=case when p_kind='entrada' then quantity+p_quantity else quantity-p_quantity end where id=p_material and owner_id=v_uid;
 insert into public.movements(owner_id,material_id,kind,quantity,responsible,note) values(v_uid,p_material,p_kind,p_quantity,trim(p_responsible),coalesce(p_note,''));
end $$;
revoke all on function public.registrar_movimentacao(uuid,text,numeric,text,text) from public,anon;
grant execute on function public.registrar_movimentacao(uuid,text,numeric,text,text) to authenticated;
-- Não reinterpretar saldos ou cotações já registrados com outra unidade.
create function public.proteger_unidade_material() returns trigger language plpgsql security definer set search_path='' as $$
begin
 if new.unit <> old.unit and (old.quantity <> 0 or exists(select 1 from public.movements where material_id=old.id) or exists(select 1 from public.offers where material_id=old.id)) then
  raise exception 'A unidade não pode ser alterada após movimentações ou cotações. Cadastre outro material.';
 end if;
 return new;
end $$;
create trigger proteger_unidade before update of unit on public.materials for each row execute function public.proteger_unidade_material();
revoke all on function public.proteger_unidade_material() from public,anon,authenticated;
