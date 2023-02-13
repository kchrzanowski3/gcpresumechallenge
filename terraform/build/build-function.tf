//create a zipped file to upload the google code function to a bucket
data "archive_file" "googlerunzip" {
  type = "zip"
  output_path = "../../terraform/build/built-code/code.zip"
  source_dir = "../../Back End Files/gcpfunction/"
}
