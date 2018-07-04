require! {
    \./config.json : { url }
}
module.exports = (emailkey)-> "#url/reject-email/#{emailkey}"