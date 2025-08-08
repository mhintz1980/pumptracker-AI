import * as vscode from 'vscode';
import { RooCodeProvider } from './rooCodeProvider';

export class ChatWebviewProvider implements vscode.WebviewViewProvider {
    private _view?: vscode.WebviewView;
    private _chatHistory: Array<{ role: 'user' | 'assistant', content: string }> = [];

    constructor(
        private readonly _context: vscode.ExtensionContext,
        private readonly _rooCodeProvider: RooCodeProvider
    ) { }

    public resolveWebviewView(
        webviewView: vscode.WebviewView,
        context: vscode.WebviewViewResolveContext,
        _token: vscode.CancellationToken,
    ) {
        this._view = webviewView;

        webviewView.webview.options = {
            enableScripts: true,
            localResourceRoots: [this._context.extensionUri]
        };

        webviewView.webview.html = this._getHtmlForWebview(webviewView.webview);

        webviewView.webview.onDidReceiveMessage(async (data) => {
            switch (data.type) {
                case 'sendMessage':
                    await this.handleUserMessage(data.message);
                    break;
                case 'clearChat':
                    this.clearChat();
                    break;
            }
        });
    }

    private async handleUserMessage(message: string): Promise<void> {
        if (!this._view) {return;}

        // Add user message to history
        this._chatHistory.push({ role: 'user', content: message });

        // Update UI to show user message
        this._view.webview.postMessage({
            type: 'addMessage',
            role: 'user',
            content: message
        });

        // Show typing indicator
        this._view.webview.postMessage({
            type: 'showTyping'
        });

        try {
            // Get AI response
            const response = await this._rooCodeProvider.sendChatMessage(message);

            // Add assistant response to history
            this._chatHistory.push({ role: 'assistant', content: response });

            // Update UI with response
            this._view.webview.postMessage({
                type: 'addMessage',
                role: 'assistant',
                content: response
            });
        } catch (error) {
            this._view.webview.postMessage({
                type: 'addMessage',
                role: 'assistant',
                content: 'Sorry, I encountered an error processing your request. Please check your API configuration.'
            });
        } finally {
            // Hide typing indicator
            this._view.webview.postMessage({
                type: 'hideTyping'
            });
        }
    }

    private clearChat(): void {
        this._chatHistory = [];
        if (this._view) {
            this._view.webview.postMessage({
                type: 'clearMessages'
            });
        }
    }

    private _getHtmlForWebview(webview: vscode.Webview): string {
        return `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Roo Code Chat</title>
    <style>
        body {
            font-family: var(--vscode-font-family);
            font-size: var(--vscode-font-size);
            color: var(--vscode-foreground);
            background-color: var(--vscode-editor-background);
            margin: 0;
            padding: 10px;
            height: 100vh;
            display: flex;
            flex-direction: column;
        }
        
        .chat-container {
            flex: 1;
            overflow-y: auto;
            margin-bottom: 10px;
            padding: 10px;
            border: 1px solid var(--vscode-panel-border);
            border-radius: 4px;
        }
        
        .message {
            margin-bottom: 15px;
            padding: 8px 12px;
            border-radius: 8px;
            max-width: 90%;
        }
        
        .user-message {
            background-color: var(--vscode-button-background);
            color: var(--vscode-button-foreground);
            margin-left: auto;
            text-align: right;
        }
        
        .assistant-message {
            background-color: var(--vscode-input-background);
            border: 1px solid var(--vscode-input-border);
        }
        
        .typing-indicator {
            display: none;
            font-style: italic;
            color: var(--vscode-descriptionForeground);
            margin-bottom: 10px;
        }
        
        .input-container {
            display: flex;
            gap: 8px;
        }
        
        .message-input {
            flex: 1;
            padding: 8px;
            border: 1px solid var(--vscode-input-border);
            background-color: var(--vscode-input-background);
            color: var(--vscode-input-foreground);
            border-radius: 4px;
            font-family: inherit;
            font-size: inherit;
        }
        
        .send-button, .clear-button {
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-family: inherit;
            font-size: inherit;
        }
        
        .send-button {
            background-color: var(--vscode-button-background);
            color: var(--vscode-button-foreground);
        }
        
        .send-button:hover {
            background-color: var(--vscode-button-hoverBackground);
        }
        
        .clear-button {
            background-color: var(--vscode-button-secondaryBackground);
            color: var(--vscode-button-secondaryForeground);
        }
        
        .clear-button:hover {
            background-color: var(--vscode-button-secondaryHoverBackground);
        }
        
        .welcome-message {
            text-align: center;
            color: var(--vscode-descriptionForeground);
            font-style: italic;
            margin: 20px 0;
        }
        
        pre {
            background-color: var(--vscode-textCodeBlock-background);
            padding: 8px;
            border-radius: 4px;
            overflow-x: auto;
            white-space: pre-wrap;
        }
        
        code {
            background-color: var(--vscode-textCodeBlock-background);
            padding: 2px 4px;
            border-radius: 2px;
            font-family: var(--vscode-editor-font-family);
        }
    </style>
</head>
<body>
    <div class="chat-container" id="chatContainer">
        <div class="welcome-message">
            Welcome to Roo Code AI Assistant! Ask me anything about your code or the SPARC methodology.
        </div>
    </div>
    
    <div class="typing-indicator" id="typingIndicator">
        Roo Code is thinking...
    </div>
    
    <div class="input-container">
        <input type="text" class="message-input" id="messageInput" placeholder="Ask Roo Code anything..." />
        <button class="send-button" id="sendButton">Send</button>
        <button class="clear-button" id="clearButton">Clear</button>
    </div>

    <script>
        const vscode = acquireVsCodeApi();
        const chatContainer = document.getElementById('chatContainer');
        const messageInput = document.getElementById('messageInput');
        const sendButton = document.getElementById('sendButton');
        const clearButton = document.getElementById('clearButton');
        const typingIndicator = document.getElementById('typingIndicator');

        function addMessage(role, content) {
            const messageDiv = document.createElement('div');
            messageDiv.className = \`message \${role}-message\`;
            
            // Simple markdown-like formatting
            const formattedContent = content
                .replace(/\`\`\`([\\s\\S]*?)\`\`\`/g, '<pre><code>$1</code></pre>')
                .replace(/\`([^\`]+)\`/g, '<code>$1</code>')
                .replace(/\\n/g, '<br>');
            
            messageDiv.innerHTML = formattedContent;
            chatContainer.appendChild(messageDiv);
            chatContainer.scrollTop = chatContainer.scrollHeight;
        }

        function sendMessage() {
            const message = messageInput.value.trim();
            if (!message) return;

            vscode.postMessage({
                type: 'sendMessage',
                message: message
            });

            messageInput.value = '';
        }

        function clearChat() {
            vscode.postMessage({
                type: 'clearChat'
            });
        }

        sendButton.addEventListener('click', sendMessage);
        clearButton.addEventListener('click', clearChat);

        messageInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendMessage();
            }
        });

        // Handle messages from extension
        window.addEventListener('message', event => {
            const message = event.data;
            
            switch (message.type) {
                case 'addMessage':
                    addMessage(message.role, message.content);
                    break;
                case 'showTyping':
                    typingIndicator.style.display = 'block';
                    break;
                case 'hideTyping':
                    typingIndicator.style.display = 'none';
                    break;
                case 'clearMessages':
                    chatContainer.innerHTML = '<div class="welcome-message">Chat cleared. How can I help you?</div>';
                    break;
            }
        });
    </script>
</body>
</html>`;
    }
}