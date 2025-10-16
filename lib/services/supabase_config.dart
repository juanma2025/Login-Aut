const String supabaseUrl = 'https://jivqhrragkcalmljvyyd.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImppdnFocnJhZ2tjYWxtbGp2eXlkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA1NTQ5NzYsImV4cCI6MjA3NjEzMDk3Nn0.xT-pAyZz3fnBBEBh6_hS4JA11c9xK8LSNu170-9GWlQ';

/// Nombre del bucket en Supabase Storage para audios
const String soundsBucket = 'sounds';

/// Categorías sugeridas para etiquetar sonidos
const List<String> defaultTags = [
  'voz',
  'percusión',
  'ambiental',
  'melodía',
  'fx',
];