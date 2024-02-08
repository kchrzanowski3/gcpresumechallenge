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
    
function linkedinredirect() {
    window.location.href = "https://www.linkedin.com/in/kylechrzanowski/"; // Replace with your target URL
}