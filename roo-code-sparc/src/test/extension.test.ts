import * as assert from 'assert';
import * as vscode from 'vscode';
import { ConfigurationManager } from '../utils/configurationManager';

suite('Extension Test Suite', () => {
    vscode.window.showInformationMessage('Start all tests.');

    test('Configuration Manager Test', () => {
        const configManager = new ConfigurationManager();

        // Test default provider
        const defaultProvider = configManager.getCurrentProvider();
        assert.strictEqual(typeof defaultProvider, 'string');

        // Test default model
        const defaultModel = configManager.getCurrentModel();
        assert.strictEqual(typeof defaultModel, 'string');

        // Test model config
        const modelConfig = configManager.getModelConfig();
        assert.strictEqual(typeof modelConfig.provider, 'string');
        assert.strictEqual(typeof modelConfig.model, 'string');
    });

    test('SPARC Integration Enabled', () => {
        const configManager = new ConfigurationManager();
        const sparcEnabled = configManager.isSparcIntegrationEnabled();
        assert.strictEqual(typeof sparcEnabled, 'boolean');
    });
});