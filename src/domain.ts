export type Material = {id:string; name:string; description:string; category:string; unit:string; quantity:number; minimum:number; location:string; code:string; replenishment_status:string; created_at:string}
export type Supplier = {id:string; name:string; contact:string; phone:string; email:string; created_at:string}
export type Offer = {id:string; material_id:string; supplier_id:string; package_description:string; quantity:number; price:number; quoted_at:string}
export type Movement = {id:string; material_id:string; kind:'entrada'|'saída'; quantity:number; responsible:string; note:string; created_at:string}
export function validateMaterial(name:string, unit:string, minimum:number) { if(!name.trim()) return 'Informe o nome do material.'; if(!unit.trim()) return 'Informe a unidade de medida.'; if(!Number.isFinite(minimum)||minimum<0) return 'O estoque mínimo deve ser zero ou maior.'; return '' }
export function nextStock(current:number, kind:'entrada'|'saída', amount:number) { if(!Number.isFinite(amount)||amount<=0) throw new Error('Informe uma quantidade maior que zero.'); if(kind==='saída' && amount>current) throw new Error('Quantidade maior que o estoque disponível.'); return kind==='entrada'?current+amount:current-amount }
export function unitPrice(price:number, quantity:number) { if(!Number.isFinite(price)||price<0||!Number.isFinite(quantity)||quantity<=0) throw new Error('Preço ou quantidade inválida.'); return price/quantity }
export function need(m:Material) { return Number(m.minimum)>0 && Number(m.quantity)<Number(m.minimum) }
export function priority(m:Material) { return Number(m.quantity)<=Number(m.minimum)*0.25?'Urgente':'Atenção' }
export const num = (n:number|string) => Number(n).toLocaleString('pt-BR',{maximumFractionDigits:3})
export const money = (n:number) => n.toLocaleString('pt-BR',{style:'currency',currency:'BRL',maximumFractionDigits:4})
