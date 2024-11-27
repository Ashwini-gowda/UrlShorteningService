# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:
## Installation
 >- [Steps for installing Rails](https://gorails.com/setup/osx/10.13-high-sierra)
1.1 Correct ruby version
This project uses ruby ruby 3.2.2 with [rvm](https://rvm.io/rvm/install) installed ensure presence
```
    rvm install 3.2.2
    gem install bundler
```
1.2 All libraries and their versions

  ``` 
    bundle install
  ```
1.3 Env setup
  use this command to  edit credential.yml.enc file, update the secret token 
  ```
    VISUAL="code --wait" bin/rails credentials:edit
  ```
1.3 to start server
  ```
    rails s
  ```
1.4 To run Rspec  
  ```
    rspec spec/controllers/api/v1/url_shorteners_controller_spec.rb
  ```
1.5 To generate Swagger Doc
  ```
   rake rswag:specs:swaggerize
  ```
  - after running the above command then start the server to access the swagger doc use this url - http://localhost:3000/api-docs
1.6 local Server running url
   ```
   http://localhost:3000
   ```

1.7 API post collection 
- In the Header section add ***Authorization** filed to with token ,token should same as the secret token added in the credential.yml.enc file
- postman collect doc avaialble in the repo, import that collection into your postman workspace
  ```
  file name: URLShorterns APIs.postman_collection.json
  ```

