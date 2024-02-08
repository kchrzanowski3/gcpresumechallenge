function totalvisitors() {
    fetch('https://kyle-resume-api-gateway-3ti78e4q.ue.gateway.dev/getvisitors')
        .then(res => res.json())
        .then(res => {document.getElementById("visitorCount") = Number(res.body.count)})
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
    
    