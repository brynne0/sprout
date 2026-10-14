import { computed, ref } from 'vue'
import type { Session } from '@supabase/supabase-js'
import { supabase } from '@/lib/supabase'

const session = ref<Session | null>(null)

// Resolves once supabase-js has restored a saved session or picked one up
// from a magic-link redirect.
const ready = supabase.auth.getSession().then(({ data }) => {
  session.value = data.session
})

supabase.auth.onAuthStateChange((_event, newSession) => {
  session.value = newSession
})

export function useAuth() {
  const isAuthenticated = computed(() => session.value !== null)

  async function signInWithEmail(email: string) {
    const { error } = await supabase.auth.signInWithOtp({
      email,
      options: { emailRedirectTo: `${window.location.origin}/auth/callback` },
    })
    if (error) throw error
  }

  async function signOut(scope: 'global' | 'local' = 'global') {
    await supabase.auth.signOut({ scope })
  }

  return { session, isAuthenticated, ready, signInWithEmail, signOut }
}
