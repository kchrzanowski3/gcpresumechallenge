let countertext1
let countertext2

describe('tests the website is up and the API is working', () => {

  it('Visits kylechrzanowski.com and gets the visitor count', () => {
    cy.visit('https://kylechrzanowski.com')
    cy.contains('Kyle Chrzanowski')
    cy.visit('https://kylechrzanowski.com')
    cy.get('[id=counter]',{ timeout: 10000 })
        .invoke('text')
        .should('match', /^[0-9]*$/)
    cy.get('[id=counter]').then(($counter) => {
      // save text from the first element
      countertext1 = $counter.text()
    })
  })


  it('reloads and checks the updated visitor count has increased by 1', () => {
    cy.visit('https://kylechrzanowski.com')
    cy.get('[id=counter]', { timeout: 10000 })
        .invoke('text')
        .should('match', /^[0-9]*$/)
    cy.get('[id=counter]').then(($counter) => {
      // save text from the first element
      countertext2 = $counter.text()

      expect(String(Number(countertext1)+1)).to.equal(countertext2)
    })
  })



})





