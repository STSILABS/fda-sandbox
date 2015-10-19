require 'spec_helper.rb'

feature "Drug Detail", js: true do

  include Helpers::DrugHelpers

  before :each do 
    setup_drug_data
    sleep(2) # avoid API rate limit
  end

  scenario "basic information", smoke:true do
    visit "/#/drug/#{@viagra.product_ndc}"
    expect(page).to have_content "Viagra"
    # Generic Name
    expect(page).to have_content "SILDENAFIL CITRATE"
    # Effects 
    expect(page).to have_content "DYSPNOEA"
  end # typeahead

  scenario "upvote", smoke:true do 
    visit "/#/drug/#{@viagra.product_ndc}"
    expect(page).to have_css 'div#upvoteCount', text:"0"
    click_button 'upvoteButton'
    expect(page).to have_css 'div#upvoteCount', text:"1"
  end

  scenario "info on recalls" do
    visit "/#/drug/#{@viagra.product_ndc}" 
    expect(page).to have_content "Recalls: 0"
    visit "/#/drug/#{@advilpm.product_ndc}" 
    expect(page).to have_content "Recalls: 1"
  end # typeahead

  scenario "links to alternative drugs" do
    visit "/#/drug/#{@viagra.product_ndc}"
    expect(page).to have_content "Viagra" 
    # page.find(:a, "Revatio").first.click
    first(:link, "Revatio").click
    expect(page).to have_content "Revatio"
  end # typeahead

end 

