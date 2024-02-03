import 'cypress-plugin-api'
let res2
let res1

describe('tests the website is up and the API is working', () => {

  it('Visits ${website_address}', () => {
    
    cy.visit('${website_address}')
    cy.contains('Kyle Chrzanowski')
  })

  it('call the api #1 and store the value', () => {
    cy.request('${api_address}/${api_path}').as('details')
        //validate
        cy.get('@details').its('status').should('eq',200)
        cy.get('@details').then((response)  => {
          res1 = response.body.body.count
          cy.log(res1)
        })

        //.get('body').its('count') //.should('match', /^[0-9]*$/)

    })

    it('call the api #2 and check it gets incremented', () => {
        cy.request('${api_address}/${api_path}').as('details')
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





