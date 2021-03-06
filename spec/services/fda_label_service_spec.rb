require 'spec_helper'

RSpec.describe FdaLabelService do

  before :each do 
    @lipitor_ndc = "0071-0156"
    @zinc_ndc    = "0168-0062" 
  end

  describe "find by product ndc" do 

    before :each do 
      sleep(0.3) # avoid API rate limit
    end

    it "should return a result for a specific ndc" do 
      expect( FdaLabelService.find_by_product_ndc(@lipitor_ndc) ).to be_a Hash
      expect( FdaLabelService.find_by_product_ndc(@lipitor_ndc)["indications_and_usage"] ).to be_present
    end

    it "should return no result for a bad ndc" do 
      expect( FdaLabelService.find_by_product_ndc("dkdjkjkjdkjfkj3k3j43k4343") ).to_not be_present
    end

    describe "normalizing ndc format" do 

      it "should add a zero padding to product code" do 
        ndc = "55289-038"
        expect( FdaLabelService.find_by_product_ndc(ndc)["indications_and_usage"] ).to be_present
        ndc = "63868-0089"
        expect( FdaLabelService.find_by_product_ndc(ndc)["indications_and_usage"] ).to be_present
      end

    end # normalize

  end # find by product ndc"

  describe "caching" do 

    before :each do 
      @api_regex=/.*fda.gov*/
    end

    it "should cache first request of a type" do 
      expect{
        FdaLabelService.find_by_product_ndc(@lipitor_ndc)
      }.to change{ServiceCache.count}.by(1)
      expect(WebMock).to have_requested(:any, @api_regex)
    end

    it "should send an http request on first request, but not duplicate" do
      first_result = FdaLabelService.find_by_product_ndc(@lipitor_ndc)
      expect(WebMock).to have_requested(:any, @api_regex).once
      # should cache the above and serve it next time (below)
      second_result = FdaLabelService.find_by_product_ndc(@lipitor_ndc)
      expect(WebMock).to have_requested(:any, @api_regex).once
      # both results should have the same data
      expect(first_result).to eq second_result
      # but then should do a live call for a new NDC
      third_result = FdaLabelService.find_by_product_ndc(@zinc_ndc)
      expect(WebMock).to have_requested(:any, @api_regex).twice
    end 

  end # caching


end
