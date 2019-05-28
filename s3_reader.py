import binascii
import boto3
import gzip
import os
import shutil


file_path = 'XXXXX'


def is_gz_file(filename):
    with open(filename, 'rb') as test_f:
        return binascii.hexlify(test_f.read(2)) == b'1f8b'


s3_bucket = boto3.resource(
    's3',
    aws_access_key_id='XXXXX',
    aws_secret_access_key='XXXXX',
    region_name='XXXXX'
).Bucket('XXXXX')

try:
    s3_bucket.download_file(file_path, file_path)
except Exception as exc:
    print('Error downloading file {}: {}.'.format(file_path, exc))
    exit(1)

print('Success downloading file {}.'.format(file_path))

if is_gz_file(file_path):
    decompressed_file_name = 'decompressed-' + file_path
    with open(file_path, 'rb') as fp, open(decompressed_file_name, 'w+') as decompressed_fp:
        fp.seek(0)
        with gzip.GzipFile(fileobj=fp, mode='rb') as gz:
            shutil.copyfileobj(gz, decompressed_fp)
    os.remove(os.path.join(os.getcwd(), file_path))
    file_name = decompressed_file_name
