import * as vscode from 'vscode';
import { RooCodeProvider } from './rooCodeProvider';

export interface SparcPhase {
    name: string;
    description: string;
    template: string;
    nextPhase?: string;
}

export class SparcMethodologyProvider {
    private readonly phases: Map<string, SparcPhase> = new Map([
        ['specification', {
            name: 'Specification',
            description: 'Define requirements and objectives',
            template: `# SPARC Specification Phase

## Project Overview
- **Objective**: [Describe the main goal]
- **Scope**: [Define what's included/excluded]
- **Success Criteria**: [How will you measure success]

## Requirements
### Functional Requirements
- [ ] [Requirement 1]
- [ ] [Requirement 2]

### Non-Functional Requirements
- [ ] Performance: [Specify requirements]
- [ ] Security: [Specify requirements]
- [ ] Scalability: [Specify requirements]

## Constraints
- [List any technical, time, or resource constraints]

## Assumptions
- [List key assumptions]`,
            nextPhase: 'pseudocode'
        }],
        ['pseudocode', {
            name: 'Pseudocode',
            description: 'Create high-level algorithmic design',
            template: `# SPARC Pseudocode Phase

## Algorithm Design

### Main Flow
\`\`\`
BEGIN [ProjectName]
    // High-level steps
    1. [Step 1]
    2. [Step 2]
    3. [Step 3]
END
\`\`\`

### Key Functions
\`\`\`
FUNCTION [FunctionName](parameters)
    // Function logic
    RETURN result
END FUNCTION
\`\`\`

### Data Structures
- [Structure 1]: [Description]
- [Structure 2]: [Description]

### Error Handling
- [Error scenario 1]: [Handling approach]
- [Error scenario 2]: [Handling approach]`,
            nextPhase: 'architecture'
        }],
        ['architecture', {
            name: 'Architecture',
            description: 'Design system architecture and components',
            template: `# SPARC Architecture Phase

## System Architecture

### Component Diagram
\`\`\`
[Component A] --> [Component B]
[Component B] --> [Component C]
\`\`\`

### Technology Stack
- **Frontend**: [Technology choices]
- **Backend**: [Technology choices]
- **Database**: [Technology choices]
- **Infrastructure**: [Technology choices]

### Design Patterns
- [Pattern 1]: [Usage and rationale]
- [Pattern 2]: [Usage and rationale]

### API Design
\`\`\`
GET /api/[resource]
POST /api/[resource]
PUT /api/[resource]/:id
DELETE /api/[resource]/:id
\`\`\`

### Security Considerations
- Authentication: [Approach]
- Authorization: [Approach]
- Data Protection: [Approach]`,
            nextPhase: 'refinement'
        }],
        ['refinement', {
            name: 'Refinement',
            description: 'Optimize and improve the design',
            template: `# SPARC Refinement Phase

## Performance Optimization
- [Optimization 1]: [Description and impact]
- [Optimization 2]: [Description and impact]

## Code Quality Improvements
- [ ] Code review checklist
- [ ] Testing strategy
- [ ] Documentation updates
- [ ] Error handling improvements

## Security Enhancements
- [ ] Input validation
- [ ] Output sanitization
- [ ] Access control review
- [ ] Dependency security audit

## Scalability Considerations
- [Consideration 1]: [Implementation approach]
- [Consideration 2]: [Implementation approach]

## Technical Debt
- [Debt item 1]: [Remediation plan]
- [Debt item 2]: [Remediation plan]`,
            nextPhase: 'completion'
        }],
        ['completion', {
            name: 'Completion',
            description: 'Finalize implementation and documentation',
            template: `# SPARC Completion Phase

## Implementation Status
- [ ] Core functionality complete
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] Code review completed
- [ ] Security review completed

## Deployment Checklist
- [ ] Environment configuration
- [ ] Database migrations
- [ ] Monitoring setup
- [ ] Backup procedures
- [ ] Rollback plan

## Post-Deployment
- [ ] Performance monitoring
- [ ] Error tracking
- [ ] User feedback collection
- [ ] Maintenance procedures

## Project Retrospective
### What Went Well
- [Success 1]
- [Success 2]

### What Could Be Improved
- [Improvement 1]
- [Improvement 2]

### Lessons Learned
- [Lesson 1]
- [Lesson 2]`
        }]
    ]);

    constructor(private rooCodeProvider: RooCodeProvider) { }

    async showSparcAssistant(): Promise<void> {
        const phaseNames = Array.from(this.phases.keys());
        const selectedPhase = await vscode.window.showQuickPick(phaseNames, {
            placeHolder: 'Select SPARC methodology phase'
        });

        if (!selectedPhase) {return;}

        const phase = this.phases.get(selectedPhase);
        if (!phase) {return;}

        const action = await vscode.window.showQuickPick([
            'Create Template',
            'Get AI Assistance',
            'Review Current Phase'
        ], {
            placeHolder: `What would you like to do for the ${phase.name} phase?`
        });

        switch (action) {
            case 'Create Template':
                await this.createPhaseTemplate(phase);
                break;
            case 'Get AI Assistance':
                await this.getAIAssistance(phase);
                break;
            case 'Review Current Phase':
                await this.reviewCurrentPhase(phase);
                break;
        }
    }

    private async createPhaseTemplate(phase: SparcPhase): Promise<void> {
        const document = await vscode.workspace.openTextDocument({
            content: phase.template,
            language: 'markdown'
        });
        await vscode.window.showTextDocument(document);
    }

    private async getAIAssistance(phase: SparcPhase): Promise<void> {
        const context = await this.getCurrentContext();
        const prompt = `I'm working on the ${phase.name} phase of the SPARC methodology. ${phase.description}.

Current context:
${context}

Please provide specific guidance and suggestions for this phase. Include actionable items and best practices.`;

        try {
            const response = await this.rooCodeProvider.sendChatMessage(prompt);
            await this.showResponse(`SPARC ${phase.name} Assistance`, response);
        } catch (error) {
            vscode.window.showErrorMessage(`Failed to get AI assistance: ${error}`);
        }
    }

    private async reviewCurrentPhase(phase: SparcPhase): Promise<void> {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            vscode.window.showWarningMessage('Please open a document to review');
            return;
        }

        const content = editor.document.getText();
        const prompt = `Please review this ${phase.name} phase document for completeness and quality:

${content}

Provide feedback on:
1. Completeness - are all necessary sections covered?
2. Quality - is the content detailed and actionable?
3. SPARC methodology alignment - does it follow best practices?
4. Suggestions for improvement`;

        try {
            const response = await this.rooCodeProvider.sendChatMessage(prompt);
            await this.showResponse(`${phase.name} Phase Review`, response);
        } catch (error) {
            vscode.window.showErrorMessage(`Failed to review phase: ${error}`);
        }
    }

    private async getCurrentContext(): Promise<string> {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {return 'No active document';}

        const selection = editor.selection;
        if (!selection.isEmpty) {
            return `Selected text:\n${editor.document.getText(selection)}`;
        }

        return `Current file: ${editor.document.fileName}\nLanguage: ${editor.document.languageId}`;
    }

    private async showResponse(title: string, content: string): Promise<void> {
        const document = await vscode.workspace.openTextDocument({
            content: `# ${title}\n\n${content}`,
            language: 'markdown'
        });
        await vscode.window.showTextDocument(document);
    }
}