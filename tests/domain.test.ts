import {describe,it,expect} from 'vitest'
import {validateMaterial,nextStock,unitPrice} from '../src/domain'
describe('Regras essenciais',()=>{
 it('aceita material válido',()=>expect(validateMaterial('Cabo','metro',10)).toBe(''))
 it('rejeita material sem nome',()=>expect(validateMaterial(' ','metro',10)).not.toBe(''))
 it('registra saída dentro do saldo',()=>expect(nextStock(20,'saída',7)).toBe(13))
 it('impede saída maior que saldo',()=>expect(()=>nextStock(4,'saída',5)).toThrow())
 it('compara preços por unidade',()=>{expect(unitPrice(380,100)).toBe(3.8);expect(unitPrice(720,200)).toBe(3.6)})
 it('rejeita quantidade inválida na comparação',()=>expect(()=>unitPrice(100,0)).toThrow())
})
