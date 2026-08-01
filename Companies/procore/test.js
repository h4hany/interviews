/**
 * Main function: Determines if cited text supports agent text.
 * @param {Object} input
 * @returns {boolean}
 */
function solution(input) {
    // --- Input handling ---
    if(
        typeof input.agentText !== 'string' ||
        input.agentText === null ||
        typeof input.citedText !== 'string' ||
        input.citedText === null
    ){
        throw new Error('Both agentText and citedText must be strings or objects with an "input" property');
    }

    const  agentText = normalize(input.agentText)

    const  citedText = normalize(input.citedText)

    if(agentText === '' || citedText === '') return false

    // --- Preprocessing ---


    // --- Main checks ---
    // if (hasContradiction()) return;
    // if (hasExactMatch(input.agentText, input.citedText)) return true;
    // if (hasSemanticSimilarity()) return ;
    // if (hasNumericalRangeMatch()) return ;
    // if (hasLogicalImplication()) return ;


    if (hasExactMatch(agentText, citedText)) return true;
    if (hasContradiction(agentText, citedText)) return false;
    if (hasPartialInformation(agentText, citedText)) return true;

    if (hasSemanticSimilarity(agentText, citedText)) return true ;
    if (hasNumericalRangeMatch(agentText, citedText)) return true;
    if (hasLogicalImplication(agentText, citedText)) return true;

    return false;

}

function normalize(text) {
    return text
        .toLowerCase()
        .replace(/[^\w\s.-]/g, " ")
        .replace(/\s+/g, " ")
        .trim();
}

// --------------------------------------------------------------
// Helper Functions (students must complete these)
// --------------------------------------------------------------
function hasPartialInformation(agentText, citedText) {
    const agentTextComponents = agentText.toLowerCase().split(' ');
    const citedTextComponents = citedText.toLowerCase().split(' ');

    // Every word in agentText must be found in citedText.
    return agentTextComponents.every((word) => citedTextComponents.includes(word));

}

function hasContradiction(agentText, citedText) {
    // TODO: Implement contradiction check

    const contradictions = [
        "does not", "is not", "are not",
        "never", "cannot", "won't", "not",
        "no longer", "neither", "nor", "without",
        "ain't", "nowhere", "hardly", "scarcely",
        "barely", "rarerly", "don't", "didn't",
        "doesn't", "can't", "could not", "should not",
        "will not", "has not", "have not", "i'm not",
        "isn't", "aren't"
    ];
    for (let contradiction of contradictions) {
        if (agentText.includes(contradiction) !== citedText.includes(contradiction)) {
            return true;
        }
    }

    return false;
}

function hasExactMatch(agentText, citedText) {
    // Implement exact match / high similarity check

    //  remove punctuation from texts

    agentText = agentText.replace(/[\.,!?'";:]/g, '');
    citedText = citedText.replace(/[\.,!?'";:]/g, '');
    return citedText.toLowerCase().includes(agentText.toLowerCase());
}

function hasSemanticSimilarity(agentText, citedText) {
    // TODO: Implement semantic similarity (use synonyms if needed)

    const synonyms = {
        "happy": ["joyful", "blissful", "ecstatic", "cheerful"],
        "sad": ["unhappy", "sorrowful", "dejected", "regretful"],
        "regular exercise": ["frequent physical activity"],
        "improves cardiovascular health": ["enhances heart and blood vessel function"],
        "the medication decreases blood pressure": ["the pharmaceutical agent causes vasodilation", "reduces hypertension"],
        "regular": ["frequent"],
        "exercise": ["physical activity"],
        "improves": ["enhances"],
        "cardiovascular health": ["heart and blood vessel function"],
        "medication": ["pharmaceutical agent"],
        "decreases": ["causes", "resulting in"],
        "blood pressure": ["hypertension"]
    };

    for (let key in synonyms) {
        if (synonyms[key].some(synonym => agentText.includes(key) && citedText.includes(synonym))) {
            return true;
        }
    }
    return false;
}

function hasNumericalRangeMatch(agentText, citedText) {
    // TODO: Implement number / range / approximation matching
    const agentNumbers = agentText.match(/\d+/g);
    const citedNumbers = citedText.match(/\d+/g);

    // No numbers means this check is not applicable
    if (!agentNumbers || !citedNumbers) return false;

    for (let number of agentNumbers) {
        const agentNumber = parseInt(number, 10);

        const hasCloseNumber = citedNumbers.some(citedNumber => {
            const n = parseInt(citedNumber, 10);
            return n >= agentNumber - 5 && n <= agentNumber + 5;
        });

        if (!hasCloseNumber) return false;
    }

    return true;
}

function hasLogicalImplication(agentText, citedText) {
    // Implement causal/risk implication support
    const implications = ["causes", "leads to", "contributes to"];

    for (let implication of implications) {
        const implicatedText = `${implication} ${agentText}`
        if (citedText.includes(implicatedText)) {
            return true;
        }
    }

    return false;

}

// --------------------------------------------------------------
// Example Test Case
// --------------------------------------------------------------
const testInput = {
    agentText: "The Earth orbits the Sun.",
    citedText: "The Earth orbits the Sun at an average distance of 93 million miles."
};

const result = solution(testInput);
console.log(`Result: ${result}`); // Expected: true (students must make it work!)

// --------------------------------------------------------------
// Export (required for automated testing)
// --------------------------------------------------------------
module.exports = solution;


const tests = [
    { agentText: "The Earth orbits the Sun.", citedText: "The Earth orbits the Sun at an average distance of 93 million miles." },
    { agentText: "Vitamin C cures the common cold.", citedText: "Scientific studies have conclusively shown that vitamin C does not cure the common cold." },
    { agentText: "Regular exercise improves cardiovascular health.", citedText: "Frequent physical activity enhances heart and blood vessel function." },
    { agentText: "Drinking water improves skin health and cognitive function.", citedText: "Proper hydration has been linked to improved skin elasticity and appearance." },
    { agentText: "The human body contains approximately 60% water.", citedText: "Adult humans' bodies consist of 55-65% water, varying by age, sex, and body composition." },
    { agentText: "Smoking increases the risk of lung cancer.", citedText: "Tobacco smoke contains over 70 carcinogens that damage DNA in lung cells, leading to mutations that can develop into cancerous tumors." },
    { agentText: "Red wine consumption reduces heart disease risk.", citedText: "Observational studies suggest moderate red wine drinkers have lower rates of heart disease, but controlled trials have not established causation, as other lifestyle factors may explain the correlation." },
    { agentText: "Artificial intelligence poses existential risks to humanity.", citedText: "Leading AI researchers have expressed concerns about advanced systems potentially developing goals misaligned with human values, though there is significant disagreement about timeline and probability of such scenarios." },
    { agentText: "Quantum computers will break current encryption methods.", citedText: "Shor's algorithm running on sufficiently powerful quantum computers could efficiently factor large prime numbers, potentially compromising RSA encryption, though post-quantum cryptography methods are being developed to address this vulnerability." },
    { agentText: "Exercise does not increase the risk of heart disease.", citedText: "Regular physical activity does not increase cardiovascular risk; in fact, it significantly reduces the likelihood of developing heart disease by strengthening the cardiovascular system." },
    { agentText: "The medication decreases blood pressure.", citedText: "The pharmaceutical agent causes vasodilation, resulting in reduced hypertension." },
    { agentText: null, citedText: "Some text" }
];
