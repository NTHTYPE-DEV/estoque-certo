import {createClient} from '@supabase/supabase-js'
const url=import.meta.env.VITE_SUPABASE_URL, key=import.meta.env.VITE_SUPABASE_ANON_KEY
export const configured=Boolean(url&&key&&!url.includes('SEU-PROJETO')&&!key.includes('SUA_CHAVE'))
export const supabase=configured?createClient(url,key):null
