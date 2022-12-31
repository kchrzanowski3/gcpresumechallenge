
const options = {
  method: 'POST',
  headers: {
  'Content-Type': 'application/json',
  },
};

fetch('https://apigateway10-7gxty8ef.ue.gateway.dev/getvisitors',options)
  .then(data => {
    console.log(data.json());
    return data.json();
  })
  .then(post => {
    console.log(post.body);
  });