const display = document.getElementById('display');
const backendUrl = 'http://localhost:5882/calculate'; // Make sure port matches Zig server

function appendNumber(number) {
    // Avoid multiple leading zeros unless it's a decimal
    if (display.value === '0' && number !== '.') {
        display.value = number;
    } else {
        display.value += number;
    }
}

function appendOperator(operator) {
    const lastChar = display.value.slice(-1);
    // Avoid consecutive operators or starting with an operator (allow starting with minus later if needed)
    if (!['+', '-', '*', '/'].includes(lastChar) && display.value !== '') {
        display.value += operator;
    }
    // Allow starting with '-'
    else if (operator === '-' && display.value === '') {
         display.value += operator;
    }
    // Replace last operator if needed
    else if (['+', '-', '*', '/'].includes(lastChar) && display.value.length > 1) {
         display.value = display.value.slice(0, -1) + operator;
    }

}

function clearDisplay() {
    display.value = '';
}

async function calculate() {
    const expression = display.value;
    if (!expression) {
        return; // Don't calculate if display is empty
    }

    console.log(`Sending expression: ${expression}`);

    try {
        const response = await fetch(backendUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ expression: expression }),
        });

        const data = await response.json();

        if (response.ok) {
            console.log("Calculation successful:", data);
            // Handle potential floating point inaccuracies for display
            display.value = Number(data.result.toFixed(10)).toString(); // Limit precision for display
        } else {
            console.error("Calculation error:", data);
            display.value = `Error: ${data.error || 'Unknown error'}`;
        }
    } catch (error) {
        console.error('Network or fetch error:', error);
        display.value = 'Error: Backend unavailable';
    }
}

// Optional: Allow keyboard input
document.addEventListener('keydown', (event) => {
    const key = event.key;
    if (key >= '0' && key <= '9') {
        appendNumber(key);
    } else if (['+', '-', '*', '/'].includes(key)) {
        appendOperator(key);
    } else if (key === '.') {
         appendNumber('.');
    } else if (key === 'Enter' || key === '=') {
        event.preventDefault(); // Prevent default form submission if inside one
        calculate();
    } else if (key === 'Backspace') {
        display.value = display.value.slice(0, -1);
    } else if (key === 'Escape' || key.toLowerCase() === 'c') {
        clearDisplay();
    }
});
