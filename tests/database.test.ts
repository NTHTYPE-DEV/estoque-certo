import {afterAll,beforeAll,describe,expect,it} from 'vitest'
import {PGlite} from '@electric-sql/pglite'
import {readFileSync} from 'node:fs'

const pg=new PGlite()
const user='10000000-0000-4000-8000-000000000001', other='20000000-0000-4000-8000-000000000002'
let material=''
beforeAll(async()=>{
 await pg.exec(`create role anon; create role authenticated; create schema auth; create table auth.users(id uuid primary key); create function auth.uid() returns uuid language sql stable as $$ select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid $$; grant usage on schema auth to authenticated; grant execute on function auth.uid() to authenticated; insert into auth.users values ('${user}'),('${other}');`)
 await pg.exec(readFileSync('supabase/migrations/202611190001_inicial.sql','utf8'))
 await pg.exec(`set role authenticated; set request.jwt.claim.sub='${user}'`)
})
afterAll(async()=>pg.close())
describe('Migração PostgreSQL em ambiente local',()=>{
 it('cria material com saldo zero',async()=>{const r=await pg.query<{id:string}>("insert into public.materials(name,unit,minimum) values ('Cabo','metro',100) returning id");material=r.rows[0].id;expect(material).toBeTruthy()})
 it('registra entrada e saída com histórico',async()=>{await pg.query("select public.registrar_movimentacao($1,'entrada',100,'Airton','')",[material]);await pg.query("select public.registrar_movimentacao($1,'saída',30,'Airton','')",[material]);const r=await pg.query<{quantity:string}>("select quantity from public.materials where id=$1",[material]);expect(Number(r.rows[0].quantity)).toBe(70);const log=await pg.query('select * from public.movements');expect(log.rows).toHaveLength(2)})
 it('impede saída acima do saldo sem criar histórico',async()=>{await expect(pg.query("select public.registrar_movimentacao($1,'saída',71,'Airton','')",[material])).rejects.toThrow();const r=await pg.query('select * from public.movements');expect(r.rows).toHaveLength(2)})
 it('bloqueia alteração direta de saldo',async()=>{await expect(pg.query('update public.materials set quantity=999 where id=$1',[material])).rejects.toThrow()})
 it('isola dados de outras contas',async()=>{await pg.exec(`set request.jwt.claim.sub='${other}'`);const r=await pg.query('select * from public.materials');expect(r.rows).toHaveLength(0);await expect(pg.query("select public.registrar_movimentacao($1,'entrada',1,'Outro','')",[material])).rejects.toThrow();await pg.exec(`set request.jwt.claim.sub='${user}'`)})
 it('impede mudança da unidade após histórico',async()=>{await expect(pg.query("update public.materials set unit='kg' where id=$1",[material])).rejects.toThrow()})
})
describe('Proteção de quantidades',()=>{
 it('rejeita NaN no mínimo',async()=>{await expect(pg.query("insert into public.materials(name,unit,minimum) values ('Teste','unidade','NaN')")).rejects.toThrow()})
})
