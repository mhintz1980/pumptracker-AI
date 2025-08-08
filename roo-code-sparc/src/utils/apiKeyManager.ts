import * as vscode from 'vscode';

export class ApiKeyManager {
    constructor(private context: vscode.ExtensionContext) { }

    async getApiKey(provider: string): Promise<string | undefined> {
        const config = vscode.workspace.getConfiguration('rooCode');
        const configKey = `apiKey.${provider}`;

        let apiKey = config.get<string>(configKey);

        if (!apiKey) {
            // Try to get from secure storage
            apiKey = await this.context.secrets.get(`rooCode.${provider}.apiKey`);
        }

        if (!apiKey) {
            // Prompt user to enter API key
            apiKey = await this.promptForApiKey(provider);
            if (apiKey) {
                await this.storeApiKey(provider, apiKey);
            }
        }

        return apiKey;
    }

    private async promptForApiKey(provider: string): Promise<string | undefined> {
        const apiKey = await vscode.window.showInputBox({
            prompt: `Enter your ${this.getProviderDisplayName(provider)} API key`,
            password: true,
            placeHolder: 'API key will be stored securely'
        });

        return apiKey;
    }

    private async storeApiKey(provider: string, apiKey: string): Promise<void> {
        // Store in secure storage
        await this.context.secrets.store(`rooCode.${provider}.apiKey`, apiKey);

        // Also update configuration for convenience
        const config = vscode.workspace.getConfiguration('rooCode');
        await config.update(`apiKey.${provider}`, apiKey, vscode.ConfigurationTarget.Global);
    }

    async removeApiKey(provider: string): Promise<void> {
        // Remove from secure storage
        await this.context.secrets.delete(`rooCode.${provider}.apiKey`);

        // Remove from configuration
        const config = vscode.workspace.getConfiguration('rooCode');
        await config.update(`apiKey.${provider}`, undefined, vscode.ConfigurationTarget.Global);
    }

    private getProviderDisplayName(provider: string): string {
        const displayNames: { [key: string]: string } = {
            'openrouter': 'OpenRouter',
            'claude': 'Anthropic Claude',
            'openai': 'OpenAI',
            'gemini': 'Google Gemini'
        };

        return displayNames[provider] || provider;
    }

    async validateApiKey(provider: string, apiKey: string): Promise<boolean> {
        // Basic validation - check if key looks valid
        if (!apiKey || apiKey.trim().length === 0) {
            return false;
        }

        // Provider-specific validation
        switch (provider) {
            case 'openrouter':
                return apiKey.startsWith('sk-or-');
            case 'openai':
                return apiKey.startsWith('sk-');
            case 'claude':
                return apiKey.startsWith('sk-ant-');
            case 'gemini':
                return apiKey.length > 20; // Basic length check
            default:
                return true; // Allow unknown providers
        }
    }

    async listConfiguredProviders(): Promise<string[]> {
        const config = vscode.workspace.getConfiguration('rooCode');
        const providers: string[] = [];

        const providerKeys = ['openrouter', 'claude', 'openai', 'gemini'];

        for (const provider of providerKeys) {
            const apiKey = await this.getApiKey(provider);
            if (apiKey) {
                providers.push(provider);
            }
        }

        return providers;
    }
}