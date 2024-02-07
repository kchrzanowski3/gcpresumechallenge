function totalvisitors() {
    fetch('https://kyle-resume-api-gateway-3ti78e4q.ue.gateway.dev/getvisitors')
        .then(res => res.json())
        .then(res => {document.getElementById("counter").innerHTML = Number(res.body.count)})
        .then(data => console.log(data));
}

function dropdowns() {
    const questionBoxes = document.querySelectorAll('.question-box');

    questionBoxes.forEach(box => {
    box.addEventListener('click', () => {
        const answer = box.querySelector('.answer');
        answer.display = answer.display === 'block' ? 'none' : 'block';
    });
});
}
    
    