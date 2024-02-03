fetch('${api_link}')
    .then(res => res.json())
    .then(res => {document.getElementById("counter").innerHTML = Number(res.body.count)})
    .then(data => console.log(data));