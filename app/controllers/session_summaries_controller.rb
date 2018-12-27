class SessionSummariesController < ApplicationController
  def show
    json = <<'EOS'
{
   "id":{
      "$oid":"5c1a1b63c80f3e2037820bdd"
   },
   "keyword":{
      "_id":{
         "$oid":"5c1a2041b2579822442a80e5"
      },
      "name":"金閣寺",
      "type":null
   },
   "count":2,
   "qas":[
      {
         "_id":{
            "$oid":"5c1a1b63c80f3e2037820bed"
         },
         "a":"金閣寺への行き方はこちらです",
         "date":"2018-11-13 01:13:33 UTC",
         "kind_no":1,
         "q":"金閣寺はどこですか",
         "scenario_no":2
      },
      {
         "_id":{
            "$oid":"5c1a1b63c80f3e2037820bec"
         },
         "a":"申し訳ございませんundefined京都への行き方の情報は現在わかりません",
         "date":"2018-11-13 01:24:18 UTC",
         "kind_no":null,
         "q":"金閣寺へ行きたいのですが",
         "scenario_no":null
      }
   ],
   "url":"http://0.0.0.0:3000/session_summaries/5c1a1b63c80f3e2037820bdd.json"
}
EOS
  item = JSON.parse(json)
  render json: item
  end
end
