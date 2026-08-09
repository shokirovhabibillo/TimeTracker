/// Fill these in once you've created your Supabase project
/// (Settings → API in the Supabase dashboard). Until both are set,
/// the Parent-Child feature stays gracefully disabled — everything
/// else in the app works normally offline.
class SupabaseConfig {
  static const String url = 'YOUR_SUPABASE_URL'; // e.g. https://xxxxx.supabase.co
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';

  static bool get isConfigured =>
      url != 'YOUR_SUPABASE_URL' && anonKey != 'YOUR_SUPABASE_ANON_KEY' && url.isNotEmpty && anonKey.isNotEmpty;
}
