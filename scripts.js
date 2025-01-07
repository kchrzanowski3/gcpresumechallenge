// REMEMBER THIS FILE GETS JENERATED BY A TEMPLATE FILE UPON DEPLOYMENT AND OVERWRITTEN

function totalvisitors() {
    fetch('${api_link}')
        .then(res => res.json())
        .then(res => {document.getElementById("visitorCount").innerHTML = Number(res.body.count)})
        .then(data => console.log(data));
}

function dropdowns(event) {    
    const questionBox = event.currentTarget;  
    const answer = questionBox.querySelector('.answer');
    const expandIcon = questionBox.querySelector('.expand-icon');

    answer.classList.toggle('show')

    //answer.classList.toggle('display'); // Toggle the visibility of the answer

    // Rotate the expand icon
    if (expandIcon.textContent === '+') {
        expandIcon.textContent = '-';
    } else {
        expandIcon.textContent = '+';
    }
}

function dropdownsSummary(event) {    
    const questionBox = event.currentTarget;  
    const answerSummary = questionBox.querySelector('.answerSummary');
    const expandIcon = questionBox.querySelector('.expand-icon');

    answerSummary.classList.toggle('show'); 

    // Rotate the expand icon (no changes needed here)
    if (expandIcon.textContent === '+') {
        expandIcon.textContent = '-';
    } else {
        expandIcon.textContent = '+';
    }
} 
    
function linkedinredirect() {
    window.location.href = "https://www.linkedin.com/in/kylechrzanowski/"; // Replace with your target URL
}

function emailme() {
    window.location.href = "mailto:kylenowski@google.com?subject=Nice to Meet You! &body=Hi Kyle, I saw your website and..."; 
}
