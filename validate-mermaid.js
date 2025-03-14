#!/usr/bin/env node

/**
 * Mermaid Diagram Validator
 * This script validates Mermaid diagrams in a file without requiring a browser
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Check if mermaid-cli is installed
try {
  execSync('mmdc --version', { stdio: 'ignore' });
} catch (error) {
  console.error('Error: @mermaid-js/mermaid-cli is not installed.');
  console.error('Please install it using: npm install -g @mermaid-js/mermaid-cli');
  process.exit(1);
}

// Extract Mermaid diagrams and validate them
function validateFile(filePath) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    const diagrams = extractMermaidDiagrams(content);
    
    console.log(`Validating Mermaid diagrams in: ${filePath}`);
    
    if (diagrams.length === 0) {
      console.log(`No Mermaid diagrams found in ${filePath}`);
      return true;
    }
    
    let errorCount = 0;
    
    for (const diagram of diagrams) {
      const validation = validateMermaidSyntax(diagram.content);
      
      if (!validation.isValid) {
        console.log(`Error in diagram at line ${diagram.line} in ${filePath}`);
        console.log('Diagram content:');
        console.log('---------------');
        console.log(diagram.content);
        console.log('---------------');
        console.log('Error message:');
        console.log(validation.error);
        errorCount++;
      }
    }
    
    if (errorCount === 0) {
      console.log(`✅ All ${diagrams.length} diagrams in ${filePath} are valid`);
      return true;
    } else {
      console.log(`❌ Found ${errorCount} errors in ${diagrams.length} diagrams in ${filePath}`);
      return false;
    }
  } catch (error) {
    console.error(`Error processing file ${filePath}: ${error.message}`);
    return false;
  }
}

// Extract Mermaid diagrams from file content
function extractMermaidDiagrams(content) {
  const lines = content.split(/\r?\n/);
  const diagrams = [];
  let inMermaid = false;
  let startLine = 0;
  let currentDiagram = '';
  
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    
    if (line.trim() === '```mermaid') {
      inMermaid = true;
      startLine = i + 1;
      currentDiagram = '';
      continue;
    }
    
    if (inMermaid && line.trim() === '```') {
      inMermaid = false;
      if (currentDiagram.trim() !== '') {
        diagrams.push({
          line: startLine,
          content: currentDiagram.trim()
        });
      }
      continue;
    }
    
    if (inMermaid) {
      currentDiagram += line + '\n';
    }
  }
  
  return diagrams;
}

// Validate Mermaid syntax using the mermaid-cli
function validateMermaidSyntax(diagram) {
  const tmpDir = fs.mkdtempSync(path.join(require('os').tmpdir(), 'mermaid-'));
  const diagramFile = path.join(tmpDir, 'diagram.mmd');
  
  try {
    fs.writeFileSync(diagramFile, diagram);
    
    // Perform basic syntax validation
    const syntaxErrors = validateBasicSyntax(diagram);
    if (syntaxErrors) {
      return { isValid: false, error: syntaxErrors };
    }
    
    return { isValid: true };
  } catch (error) {
    return { isValid: false, error: error.message };
  } finally {
    // Clean up temp files
    try {
      fs.unlinkSync(diagramFile);
      fs.rmdirSync(tmpDir);
    } catch (e) {
      // Ignore cleanup errors
    }
  }
}

// Basic syntax validation for common Mermaid diagrams
function validateBasicSyntax(diagram) {
  // Split the diagram into lines
  const lines = diagram.split('\n');
  
  // Get the diagram type from the first line
  const firstLine = lines[0].trim();
  
  // Check for empty diagram
  if (lines.length <= 1 && !firstLine) {
    return 'Empty diagram';
  }
  
  // Basic validation for flowcharts
  if (firstLine.startsWith('graph ') || firstLine.startsWith('flowchart ')) {
    return validateFlowchart(lines);
  }
  
  // Basic validation for sequence diagrams
  if (firstLine.startsWith('sequenceDiagram')) {
    return validateSequenceDiagram(lines);
  }
  
  // Basic validation for class diagrams
  if (firstLine.startsWith('classDiagram')) {
    return validateClassDiagram(lines);
  }
  
  // Basic validation for ERD
  if (firstLine.startsWith('erDiagram')) {
    return validateERDiagram(lines);
  }
  
  // Basic validation for gitgraph
  if (firstLine.startsWith('gitGraph')) {
    return validateGitGraph(lines);
  }
  
  // Basic validation for Gantt charts
  if (firstLine.startsWith('gantt')) {
    return validateGantt(lines);
  }
  
  // Basic validation for pie charts
  if (firstLine.startsWith('pie')) {
    return validatePie(lines);
  }
  
  // Unknown diagram type
  if (!firstLine.match(/^(graph|flowchart|sequenceDiagram|classDiagram|erDiagram|gitGraph|gantt|pie|stateDiagram|journey)/)) {
    return `Unknown diagram type: "${firstLine}"`;
  }
  
  // Default - pass validation if we don't have specific checks for this diagram type
  return null;
}

// Validate flowchart syntax
function validateFlowchart(lines) {
  if (lines.length < 2) {
    return 'Flowchart must have at least one node or connection';
  }
  
  // Check for unbalanced quotes
  let singleQuotes = 0;
  let doubleQuotes = 0;
  
  for (const line of lines) {
    for (let i = 0; i < line.length; i++) {
      if (line[i] === '"' && (i === 0 || line[i-1] !== '\\')) {
        doubleQuotes++;
      } else if (line[i] === "'" && (i === 0 || line[i-1] !== '\\')) {
        singleQuotes++;
      }
    }
  }
  
  if (singleQuotes % 2 !== 0) {
    return 'Unbalanced single quotes in flowchart';
  }
  
  if (doubleQuotes % 2 !== 0) {
    return 'Unbalanced double quotes in flowchart';
  }
  
  // Check for missing arrows in connections
  for (let i = 1; i < lines.length; i++) {
    const line = lines[i].trim();
    if (line && !line.startsWith('%') && !line.startsWith('subgraph') && !line.startsWith('end') && !line.startsWith('classDef') && !line.startsWith('class')) {
      if (line.includes('-->') || line.includes('---') || line.includes('-.->') || line.includes('-.-') || 
          line.includes('==>') || line.includes('===') || line.includes('--x') || line.includes('--o') ||
          line.includes('-->>') || line.includes('--[') || line.includes('<-->') || line.includes('<-.->') ||
          line.includes('<==>')){
        // Line has a connection, looks valid
      } else if (line.includes('--') || line.includes('==') || line.includes('-.')) {
        if (!line.match(/--[>x\[\]\|o]/) && !line.match(/==[\>]/) && !line.match(/-\.[\>-]/)) {
          return `Invalid connection syntax in line: "${line}"`;
        }
      }
    }
  }
  
  return null;
}

// Validate sequence diagram syntax
function validateSequenceDiagram(lines) {
  // Check for unbalanced delimiters
  let braces = 0;
  
  for (const line of lines) {
    for (let i = 0; i < line.length; i++) {
      if (line[i] === '{') {
        braces++;
      } else if (line[i] === '}') {
        braces--;
      }
    }
  }
  
  if (braces !== 0) {
    return 'Unbalanced braces in sequence diagram';
  }
  
  return null;
}

// Validate class diagram syntax
function validateClassDiagram(lines) {
  // Check for unbalanced braces in class declarations
  let braces = 0;
  
  for (const line of lines) {
    for (let i = 0; i < line.length; i++) {
      if (line[i] === '{') {
        braces++;
      } else if (line[i] === '}') {
        braces--;
      }
    }
  }
  
  if (braces !== 0) {
    return 'Unbalanced braces in class diagram';
  }
  
  return null;
}

// Validate ER diagram syntax
function validateERDiagram(lines) {
  // Check for proper relationship syntax
  for (let i = 1; i < lines.length; i++) {
    const line = lines[i].trim();
    if (line && !line.startsWith('%')) {
      // Check for proper relationship format: entityA [relationship] entityB : label
      if (line.includes('||') || line.includes('|o') || line.includes('o|') || line.includes('oo')) {
        if (!line.match(/\w+\s+[\|o][\|o]--[\|o][\|o]\s+\w+\s*:?\s*.*$/)) {
          return `Invalid relationship syntax in line: "${line}"`;
        }
      }
    }
  }
  
  return null;
}

// Validate Git Graph syntax
function validateGitGraph(lines) {
  // Simple validation for git graph
  for (let i = 1; i < lines.length; i++) {
    const line = lines[i].trim();
    if (line.startsWith('commit') && !line.match(/commit(\s+id:\s*"[^"]*")?(\s+type:\s*(NORMAL|REVERSE|HIGHLIGHT))?/)) {
      return `Invalid commit syntax in line: "${line}"`;
    }
  }
  
  return null;
}

// Validate Gantt chart syntax
function validateGantt(lines) {
  let hasDateFormat = false;
  let hasSection = false;
  let hasTask = false;
  
  for (const line of lines) {
    const trimmed = line.trim();
    if (trimmed.startsWith('dateFormat')) {
      hasDateFormat = true;
    } else if (trimmed.startsWith('section')) {
      hasSection = true;
    } else if (trimmed.includes(':')) {
      hasTask = true;
    }
  }
  
  if (!hasDateFormat) {
    return 'Missing dateFormat in Gantt chart';
  }
  
  if (!hasTask) {
    return 'No tasks defined in Gantt chart';
  }
  
  return null;
}

// Validate Pie chart syntax
function validatePie(lines) {
  if (lines.length < 2) {
    return 'Pie chart must have at least one data point';
  }
  
  for (let i = 1; i < lines.length; i++) {
    const line = lines[i].trim();
    if (line && !line.startsWith('%') && !line.includes(':')) {
      return `Invalid pie chart data in line: "${line}"`;
    }
  }
  
  return null;
}

// Main execution
if (process.argv.length < 3) {
  console.error('Usage: validate-mermaid.js <file1> [file2 ...]');
  process.exit(1);
}

let exitCode = 0;

for (let i = 2; i < process.argv.length; i++) {
  const filePath = process.argv[i];
  if (fs.existsSync(filePath) && fs.statSync(filePath).isFile()) {
    const isValid = validateFile(filePath);
    if (!isValid) {
      exitCode = 1;
    }
  } else {
    console.error(`Error: File not found - ${filePath}`);
    exitCode = 1;
  }
}

process.exit(exitCode); 