fetch('https://apigateway10-7gxty8ef.ue.gateway.dev/getvisitors')
    .then(res => res.json())
    .then(res => {document.getElementById("counter").innerHTML = res.body.count})
    .then(data => console.log(data));