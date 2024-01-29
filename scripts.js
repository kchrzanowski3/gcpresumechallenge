fetch('https://kyle-resume-api-gateway-4jnr4ia3.ue.gateway.dev/getvisitors')
    .then(res => res.json())
    .then(res => {document.getElementById("counter").innerHTML = res.body.count})
    .then(data => console.log(data));