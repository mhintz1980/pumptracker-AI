import * as vscode from 'vscode';

export interface ModelConfig {
    provider: string;
    model: string;
    maxTokens?: number;
    temperature?: number;
}

export class ConfigurationManager {
    private readonly defaultModels: { [provider: string]: string[] } = {
        'openrouter': [
            'anthropic/claude-3-sonnet-20240229',
            'anthropic/claude-3-haiku-20240307',
            'openai/gpt-4-turbo-preview',
            'openai/gpt-3.5-turbo',
            'google/gemini-pro'
        ],
        'claude': [
            'claude-3-sonnet-20240229',
            'claude-3-haiku-20240307',
            'claude-2.1'
        ],
        'openai': [
            'gpt-4-turbo-preview',
            'gpt-4',
            'gpt-3.5-turbo'
        ],
        'gemini': [
            'gemini-pro',
            'gemini-pro-vision'
        ]
    };

    getCurrentProvider(): string {
        const config = vscode.workspace.getConfiguration('rooCode');
        return config.get<string>('defaultProvider', 'openrouter');
    }

    getCurrentModel(): string {
        const config = vscode.workspace.getConfiguration('rooCode');
        return config.get<string>('defaultModel', 'anthropic/claude-3-sonnet-20240229');
    }

    getModelConfig(): ModelConfig {
        const config = vscode.workspace.getConfiguration('rooCode');

        return {
            provider: this.getCurrentProvider(),
            model: this.getCurrentModel(),
            maxTokens: config.get<number>('maxTokens', 4000),
            temperature: config.get<number>('temperature', 0.7)
        };
    }

    async switchProvider(): Promise<void> {
        const providers = Object.keys(this.defaultModels);
        const selectedProvider = await vscode.window.showQuickPick(providers, {
            placeHolder: 'Select AI provider'
        });

        if (!selectedProvider) {return;}

        const config = vscode.workspace.getConfiguration('rooCode');
        await config.update('defaultProvider', selectedProvider, vscode.ConfigurationTarget.Global);

        // Also update the default model for the new provider
        const defaultModel = this.defaultModels[selectedProvider][0];
        await config.update('defaultModel', defaultModel, vscode.ConfigurationTarget.Global);

        vscode.window.showInformationMessage(`Switched to ${selectedProvider} with model ${defaultModel}`);
    }

    async switchModel(): Promise<void> {
        const currentProvider = this.getCurrentProvider();
        const availableModels = this.defaultModels[currentProvider] || [];

        if (availableModels.length === 0) {
            vscode.window.showWarningMessage(`No models available for provider ${currentProvider}`);
            return;
        }

        const selectedModel = await vscode.window.showQuickPick(availableModels, {
            placeHolder: `Select model for ${currentProvider}`
        });

        if (!selectedModel) {return;}

        const config = vscode.workspace.getConfiguration('rooCode');
        await config.update('defaultModel', selectedModel, vscode.ConfigurationTarget.Global);

        vscode.window.showInformationMessage(`Switched to model ${selectedModel}`);
    }

    isSparcIntegrationEnabled(): boolean {
        const config = vscode.workspace.getConfiguration('rooCode');
        return config.get<boolean>('sparcIntegration', true);
    }

    isAutoSuggestEnabled(): boolean {
        const config = vscode.workspace.getConfiguration('rooCode');
        return config.get<boolean>('autoSuggest', true);
    }

    async updateConfiguration(key: string, value: any, target: vscode.ConfigurationTarget = vscode.ConfigurationTarget.Global): Promise<void> {
        const config = vscode.workspace.getConfiguration('rooCode');
        await config.update(key, value, target);
    }

    getConfiguration<T>(key: string, defaultValue: T): T {
        const config = vscode.workspace.getConfiguration('rooCode');
        return config.get<T>(key, defaultValue);
    }

    async resetToDefaults(): Promise<void> {
        const config = vscode.workspace.getConfiguration('rooCode');

        const keys = [
            'defaultProvider',
            'defaultModel',
            'maxTokens',
            'temperature',
            'sparcIntegration',
            'autoSuggest'
        ];

        for (const key of keys) {
            await config.update(key, undefined, vscode.ConfigurationTarget.Global);
        }

        vscode.window.showInformationMessage('Roo Code configuration reset to defaults');
    }

    async exportConfiguration(): Promise<void> {
        const config = vscode.workspace.getConfiguration('rooCode');
        const exportData = {
            defaultProvider: config.get('defaultProvider'),
            defaultModel: config.get('defaultModel'),
            maxTokens: config.get('maxTokens'),
            temperature: config.get('temperature'),
            sparcIntegration: config.get('sparcIntegration'),
            autoSuggest: config.get('autoSuggest')
        };

        const document = await vscode.workspace.openTextDocument({
            content: JSON.stringify(exportData, null, 2),
            language: 'json'
        });

        await vscode.window.showTextDocument(document);
        vscode.window.showInformationMessage('Configuration exported. Save this file to backup your settings.');
    }
}