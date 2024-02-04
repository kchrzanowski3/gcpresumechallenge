import 'cypress-plugin-api'
let res2
let res1

describe('tests the website is up and the API is working', () => {

  it('Visits 34.49.11.35', () => {
    
    cy.visit('34.49.11.35')
    cy.contains('Kyle Chrzanowski')
  })

  it('call the api #1 and store the value', () => {
    cy.request('kyle-resume-api-gateway-3ti78e4q.ue.gateway.dev/getvisitors').as('details')
        //validate
        cy.get('@details').its('status').should('eq',200)
        cy.get('@details').then((response)  => {
          res1 = response.body.body.count
          cy.log(res1)
        })

        //.get('body').its('count') //.should('match', /^[0-9]*$/)

    })

    it('call the api #2 and check it gets incremented', () => {
        cy.request('kyle-resume-api-gateway-3ti78e4q.ue.gateway.dev/getvisitors').as('details')
        //validate
        cy.get('@details').its('status').should('eq',200)
        cy.get('@details').then((response)  => {
            res2 = response.body.body.count
            cy.log(res2)
        })

        //.get('body').its('count') //.should('match', /^[0-9]*$/)

    })


    it('compare the api calls to have incremented by 1', () => {
        expect(Number(res1)+1).to.equal(res2)


        })

    
})





