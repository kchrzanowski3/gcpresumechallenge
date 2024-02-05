fetch('https://kyle-resume-api-gateway-3ti78e4q.ue.gateway.dev/getvisitors')
    .then(res => res.json())
    .then(res => {document.getElementById("counter").innerHTML = Number(res.body.count)})
    .then(data => console.log(data));