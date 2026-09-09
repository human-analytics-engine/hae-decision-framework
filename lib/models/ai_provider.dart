// lib/models/ai_provider.dart

enum AiProvider {
  gemini('Google Gemini', 'gemini-3.5-flash-lite', 'Günde 500 ücretsiz analiz (Google AI Studio)'),
  deepseek('DeepSeek', 'deepseek-chat', 'Ultra ucuz, derin muhakeme (DeepSeek API)'),
  openai('OpenAI (ChatGPT)', 'gpt-4o-mini', 'Hızlı ve dengeli endüstri standardı'),
  anthropic('Anthropic Claude', 'claude-3-5-haiku-20241022', 'En yüksek bilişsel nüans kabiliyeti'),
  openrouter('OpenRouter', 'deepseek/deepseek-chat', 'Tek anahtarla tüm frontier modellere erişim');

  final String label;
  final String defaultModel;
  final String description;

  const AiProvider(this.label, this.defaultModel, this.description);
}