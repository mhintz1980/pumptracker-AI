import * as vscode from 'vscode';
import { RooCodeProvider } from './providers/rooCodeProvider';
import { SparcMethodologyProvider } from './providers/sparcMethodologyProvider';
import { ChatWebviewProvider } from './providers/chatWebviewProvider';
import { ApiKeyManager } from './utils/apiKeyManager';
import { ConfigurationManager } from './utils/configurationManager';

export function activate(context: vscode.ExtensionContext) {
    console.log('Roo Code for SPARC IDE is now active!');

    // Initialize managers
    const apiKeyManager = new ApiKeyManager(context);
    const configManager = new ConfigurationManager();

    // Initialize providers
    const rooCodeProvider = new RooCodeProvider(apiKeyManager, configManager);
    const sparcProvider = new SparcMethodologyProvider(rooCodeProvider);
    const chatProvider = new ChatWebviewProvider(context, rooCodeProvider);

    // Register webview provider
    context.subscriptions.push(
        vscode.window.registerWebviewViewProvider('rooCodeChat', chatProvider)
    );

    // Register commands
    const commands = [
        vscode.commands.registerCommand('rooCode.chat', () => {
            vscode.commands.executeCommand('rooCodeChat.focus');
        }),

        vscode.commands.registerCommand('rooCode.explain', async () => {
            const editor = vscode.window.activeTextEditor;
            if (!editor) {return;}

            const selection = editor.selection;
            const selectedText = editor.document.getText(selection);

            if (!selectedText) {
                vscode.window.showWarningMessage('Please select code to explain');
                return;
            }

            await rooCodeProvider.explainCode(selectedText);
        }),

        vscode.commands.registerCommand('rooCode.generate', async () => {
            const prompt = await vscode.window.showInputBox({
                prompt: 'Describe what code you want to generate',
                placeHolder: 'e.g., Create a function that validates email addresses'
            });

            if (prompt) {
                await rooCodeProvider.generateCode(prompt);
            }
        }),

        vscode.commands.registerCommand('rooCode.refactor', async () => {
            const editor = vscode.window.activeTextEditor;
            if (!editor) {return;}

            const selection = editor.selection;
            const selectedText = editor.document.getText(selection);

            if (!selectedText) {
                vscode.window.showWarningMessage('Please select code to refactor');
                return;
            }

            const instructions = await vscode.window.showInputBox({
                prompt: 'How would you like to refactor this code?',
                placeHolder: 'e.g., Make it more efficient, add error handling'
            });

            if (instructions) {
                await rooCodeProvider.refactorCode(selectedText, instructions);
            }
        }),

        vscode.commands.registerCommand('rooCode.generateTests', async () => {
            const editor = vscode.window.activeTextEditor;
            if (!editor) {return;}

            const selection = editor.selection;
            const selectedText = editor.document.getText(selection);

            if (!selectedText) {
                vscode.window.showWarningMessage('Please select code to generate tests for');
                return;
            }

            await rooCodeProvider.generateTests(selectedText);
        }),

        vscode.commands.registerCommand('rooCode.sparcAssist', async () => {
            await sparcProvider.showSparcAssistant();
        }),

        vscode.commands.registerCommand('rooCode.switchModel', async () => {
            await configManager.switchModel();
        })
    ];

    context.subscriptions.push(...commands);

    // Register status bar item
    const statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right, 100);
    statusBarItem.text = "$(robot) Roo Code";
    statusBarItem.tooltip = "Roo Code AI Assistant";
    statusBarItem.command = 'rooCode.chat';
    statusBarItem.show();
    context.subscriptions.push(statusBarItem);

    // Show welcome message on first activation
    const hasShownWelcome = context.globalState.get('rooCode.hasShownWelcome', false);
    if (!hasShownWelcome) {
        vscode.window.showInformationMessage(
            'Welcome to Roo Code for SPARC IDE! Configure your AI API keys in settings to get started.',
            'Open Settings'
        ).then(selection => {
            if (selection === 'Open Settings') {
                vscode.commands.executeCommand('workbench.action.openSettings', 'rooCode');
            }
        });
        context.globalState.update('rooCode.hasShownWelcome', true);
    }
}

export function deactivate() {
    console.log('Roo Code for SPARC IDE is now deactivated');
}