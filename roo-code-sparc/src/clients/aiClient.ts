import { ApiKeyManager } from '../utils/apiKeyManager';
import { ConfigurationManager, ModelConfig } from '../utils/configurationManager';

export interface AIResponse {
    content: string;
    model: string;
    usage?: {
        promptTokens: number;
        completionTokens: number;
        totalTokens: number;
    };
}

export class AIClient {
    constructor(
        private apiKeyManager: ApiKeyManager,
        private configManager: ConfigurationManager
    ) { }

    async sendRequest(prompt: string): Promise<string> {
        const modelConfig = this.configManager.getModelConfig();
        const apiKey = await this.apiKeyManager.getApiKey(modelConfig.provider);

        if (!apiKey) {
            throw new Error(`No API key configured for provider: ${modelConfig.provider}`);
        }

        switch (modelConfig.provider) {
            case 'openrouter':
                return await this.sendOpenRouterRequest(prompt, modelConfig, apiKey);
            case 'claude':
                return await this.sendClaudeRequest(prompt, modelConfig, apiKey);
            case 'openai':
                return await this.sendOpenAIRequest(prompt, modelConfig, apiKey);
            case 'gemini':
                return await this.sendGeminiRequest(prompt, modelConfig, apiKey);
            default:
                throw new Error(`Unsupported provider: ${modelConfig.provider}`);
        }
    }

    private async sendOpenRouterRequest(prompt: string, config: ModelConfig, apiKey: string): Promise<string> {
        const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${apiKey}`,
                'Content-Type': 'application/json',
                'HTTP-Referer': 'https://github.com/sparc-ide/sparc-ide',
                'X-Title': 'SPARC IDE Roo Code'
            },
            body: JSON.stringify({
                model: config.model,
                messages: [
                    {
                        role: 'system',
                        content: 'You are Roo Code, an AI assistant integrated into SPARC IDE. You help developers with code generation, explanation, refactoring, and following the SPARC methodology. Be concise, helpful, and provide practical solutions.'
                    },
                    {
                        role: 'user',
                        content: prompt
                    }
                ],
                max_tokens: config.maxTokens,
                temperature: config.temperature
            })
        });

        if (!response.ok) {
            const error = await response.text();
            throw new Error(`OpenRouter API error: ${response.status} - ${error}`);
        }

        const data = await response.json() as any;
        return data.choices[0].message.content;
    }

    private async sendClaudeRequest(prompt: string, config: ModelConfig, apiKey: string): Promise<string> {
        const response = await fetch('https://api.anthropic.com/v1/messages', {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${apiKey}`,
                'Content-Type': 'application/json',
                'anthropic-version': '2023-06-01'
            },
            body: JSON.stringify({
                model: config.model,
                max_tokens: config.maxTokens,
                temperature: config.temperature,
                messages: [
                    {
                        role: 'user',
                        content: `You are Roo Code, an AI assistant integrated into SPARC IDE. You help developers with code generation, explanation, refactoring, and following the SPARC methodology. Be concise, helpful, and provide practical solutions.

${prompt}`
                    }
                ]
            })
        });

        if (!response.ok) {
            const error = await response.text();
            throw new Error(`Claude API error: ${response.status} - ${error}`);
        }

        const data = await response.json() as any;
        return data.content[0].text;
    }

    private async sendOpenAIRequest(prompt: string, config: ModelConfig, apiKey: string): Promise<string> {
        const response = await fetch('https://api.openai.com/v1/chat/completions', {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${apiKey}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                model: config.model,
                messages: [
                    {
                        role: 'system',
                        content: 'You are Roo Code, an AI assistant integrated into SPARC IDE. You help developers with code generation, explanation, refactoring, and following the SPARC methodology. Be concise, helpful, and provide practical solutions.'
                    },
                    {
                        role: 'user',
                        content: prompt
                    }
                ],
                max_tokens: config.maxTokens,
                temperature: config.temperature
            })
        });

        if (!response.ok) {
            const error = await response.text();
            throw new Error(`OpenAI API error: ${response.status} - ${error}`);
        }

        const data = await response.json() as any;
        return data.choices[0].message.content;
    }

    private async sendGeminiRequest(prompt: string, config: ModelConfig, apiKey: string): Promise<string> {
        const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/${config.model}:generateContent?key=${apiKey}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                contents: [
                    {
                        parts: [
                            {
                                text: `You are Roo Code, an AI assistant integrated into SPARC IDE. You help developers with code generation, explanation, refactoring, and following the SPARC methodology. Be concise, helpful, and provide practical solutions.

${prompt}`
                            }
                        ]
                    }
                ],
                generationConfig: {
                    temperature: config.temperature,
                    maxOutputTokens: config.maxTokens
                }
            })
        });

        if (!response.ok) {
            const error = await response.text();
            throw new Error(`Gemini API error: ${response.status} - ${error}`);
        }

        const data = await response.json() as any;
        return data.candidates[0].content.parts[0].text;
    }

    async testConnection(): Promise<boolean> {
        try {
            const response = await this.sendRequest('Hello, this is a connection test. Please respond with "Connection successful".');
            return response.toLowerCase().includes('connection successful');
        } catch (error) {
            console.error('Connection test failed:', error);
            return false;
        }
    }

    async getAvailableModels(): Promise<string[]> {
        const provider = this.configManager.getCurrentProvider();
        const apiKey = await this.apiKeyManager.getApiKey(provider);

        if (!apiKey) {
            return [];
        }

        try {
            switch (provider) {
                case 'openrouter':
                    return await this.getOpenRouterModels(apiKey);
                case 'openai':
                    return await this.getOpenAIModels(apiKey);
                default:
                    return [];
            }
        } catch (error) {
            console.error('Failed to fetch available models:', error);
            return [];
        }
    }

    private async getOpenRouterModels(apiKey: string): Promise<string[]> {
        const response = await fetch('https://openrouter.ai/api/v1/models', {
            headers: {
                'Authorization': `Bearer ${apiKey}`
            }
        });

        if (!response.ok) {
            throw new Error(`Failed to fetch OpenRouter models: ${response.status}`);
        }

        const data = await response.json() as any;
        return data.data.map((model: any) => model.id);
    }

    private async getOpenAIModels(apiKey: string): Promise<string[]> {
        const response = await fetch('https://api.openai.com/v1/models', {
            headers: {
                'Authorization': `Bearer ${apiKey}`
            }
        });

        if (!response.ok) {
            throw new Error(`Failed to fetch OpenAI models: ${response.status}`);
        }

        const data = await response.json() as any;
        return data.data
            .filter((model: any) => model.id.includes('gpt'))
            .map((model: any) => model.id);
    }
}