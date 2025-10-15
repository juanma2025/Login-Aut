const String supabaseUrl = 'https://owdmotwykmfvytyxmjyo.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im93ZG1vdHd5a21mdnl0eXhtanlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA1MzU0OTIsImV4cCI6MjA3NjExMTQ5Mn0.rwLcHItE3lSv87liUTBWaRHw4b1EKVQfz9hrNWozUU0';

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