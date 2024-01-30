fetch('https://kyle-resume-api-gateway-4jnr4ia3.ue.gateway.dev/getvisitors')
    .then(res => res.json())
    .then(res => {document.getElementById("counter").innerHTML = res.body.count})
    .then(res => {
        let count = res.body.count;
      
        // Check if the count is a number, if not, return a default value
        if (typeof count !== 'number' || isNaN(count)) { 
          count = 'ERROR (NUMBER NOT RETURNED)'; // Set a default value of 0 if it's not a valid number
        }
      
        document.getElementById("counter").innerHTML = count; 
      })
    .then(data => console.log(data));