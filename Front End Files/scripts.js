
getvisitors()
    return fetch(url,options);

const url = "https://apigateway10-7gxty8ef.ue.gateway.dev/getvisitors";

const options = {
  headers: {
    Authorization: "Bearer 6Q************"
  }
};

fetch(url, options)
  .then( res => res.json() )
  .then( data => console.log(data) );
  return data;