import * as vscode from 'vscode';
import { ApiKeyManager } from '../utils/apiKeyManager';
import { ConfigurationManager } from '../utils/configurationManager';
import { AIClient } from '../clients/aiClient';

export class RooCodeProvider {
    private aiClient: AIClient;

    constructor(
        private apiKeyManager: ApiKeyManager,
        private configManager: ConfigurationManager
    ) {
        this.aiClient = new AIClient(apiKeyManager, configManager);
    }

    async explainCode(code: string): Promise<void> {
        try {
            const prompt = `Please explain the following code in detail, including what it does, how it works, and any potential improvements:

\`\`\`
${code}
\`\`\``;

            const response = await this.aiClient.sendRequest(prompt);
            await this.showResponse('Code Explanation', response);
        } catch (error) {
            this.handleError('Failed to explain code', error);
        }
    }

    async generateCode(prompt: string): Promise<void> {
        try {
            const fullPrompt = `Generate clean, well-documented code for the following request. Include comments and follow best practices:

${prompt}

Please provide only the code with appropriate comments.`;

            const response = await this.aiClient.sendRequest(fullPrompt);
            await this.insertCodeAtCursor(response);
        } catch (error) {
            this.handleError('Failed to generate code', error);
        }
    }

    async refactorCode(code: string, instructions: string): Promise<void> {
        try {
            const prompt = `Please refactor the following code according to these instructions: ${instructions}

Original code:
\`\`\`
${code}
\`\`\`

Please provide the refactored code with explanations of the changes made.`;

            const response = await this.aiClient.sendRequest(prompt);
            await this.showResponse('Refactored Code', response);
        } catch (error) {
            this.handleError('Failed to refactor code', error);
        }
    }

    async generateTests(code: string): Promise<void> {
        try {
            const prompt = `Generate comprehensive unit tests for the following code. Include edge cases and error scenarios:

\`\`\`
${code}
\`\`\`

Please provide complete test cases using appropriate testing framework conventions.`;

            const response = await this.aiClient.sendRequest(prompt);
            await this.showResponse('Generated Tests', response);
        } catch (error) {
            this.handleError('Failed to generate tests', error);
        }
    }

    async sendChatMessage(message: string): Promise<string> {
        try {
            return await this.aiClient.sendRequest(message);
        } catch (error) {
            this.handleError('Failed to send chat message', error);
            return 'Sorry, I encountered an error processing your request.';
        }
    }

    private async showResponse(title: string, content: string): Promise<void> {
        const document = await vscode.workspace.openTextDocument({
            content: content,
            language: 'markdown'
        });
        await vscode.window.showTextDocument(document);
    }

    private async insertCodeAtCursor(code: string): Promise<void> {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            await this.showResponse('Generated Code', code);
            return;
        }

        const position = editor.selection.active;
        await editor.edit(editBuilder => {
            editBuilder.insert(position, code);
        });
    }

    private handleError(message: string, error: any): void {
        console.error(message, error);
        vscode.window.showErrorMessage(`${message}: ${error.message || error}`);
    }
}