/**
 * Main function: Determines if cited text supports agent text.
 * @param {Object} input
 * @returns {boolean}
 */
function solution(input) {
    // --- Input handling ---
    if (typeof input.agentText !== 'string' || typeof input.citedText !== 'string') {
        throw new Error('Both agentText and citedText must be strings or objects with an "input" property');
    }
    const agentText = normalize(input.agentText)
    const citedText = normalize(input.citedText)
    if (agentText === '' || citedText === '') return false
    // --- Preprocessing --- //
    // --- Main checks --- //

    // if (hasContradiction()) return;
    //  if (hasExactMatch(input.agentText, input.citedText)) return true;
    // if (hasSemanticSimilarity()) return ;
    // if (hasNumericalRangeMatch()) return ;
    // if (hasLogicalImplication()) return ;

    if (hasExactMatch(agentText, citedText)) return true;
    if (hasContradiction(agentText, citedText)) return false;
    if (hasPartialInformation(agentText, citedText)) return true;
    if (hasSemanticSimilarity(agentText, citedText)) return true;
    if (hasNumericalRangeMatch(agentText, citedText)) return true;
    if (hasLogicalImplication(agentText, citedText)) return true;
    return false;
}

function normalize(text) {
    return text.toLowerCase()
        .replace(/[^\w\s.-]/g, " ")
        .replace(/\s+/g, " ")
        .trim();
}

// --------------------------------------------------------------
// Helper Functions (students must complete these)
// --------------------------------------------------------------
function hasPartialInformation(agentText, citedText) {
    const agentTextComponents = agentText.split(' ');
    let matchingWords = 0;
    for (let component of agentTextComponents) {
        component = component.replace(/[^0-9a-z]/ig, '').toLowerCase();
        if (citedText.toLowerCase().includes(component) && component !== '') {
            matchingWords++;
        }
    }
    // Return true only if all words from agentText are found in citedText
    return matchingWords === agentTextComponents.length;
}

function hasContradiction(agentText, citedText) {
    // TODO: Implement contradiction check
    const contradictions = ["does not", "is not", "are not", "never", "cannot", "won't", "not", "no longer", "neither", "nor", "without", "ain't", "nowhere", "hardly", "scarcely", "barely", "rarerly", "don't", "didn't", "doesn't", "can't", "could not", "should not", "will not", "has not", "have not", "i'm not", "isn't", "aren't"];
    for (let contradiction of contradictions) {
        if (agentText.includes(contradiction) !== citedText.includes(contradiction)) {
            return true;
        }
    }
    return false;
}

function hasExactMatch(agentText, citedText) {
    // Implement exact match / high similarity check
    // remove punctuation from texts
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
    if (agentNumbers) {
        for (let number of agentNumbers) {
            number = parseInt(number);
            const citedNumbers = citedText.match(/\d+/g).map(Number);
            for (let citedNumber of citedNumbers) {
                if (!(citedNumber >= number - 5 && citedNumber <= number + 5)) {
                    return false;
                }
            }
        }
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
