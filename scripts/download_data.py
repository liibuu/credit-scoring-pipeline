import os
from dotenv import load_dotenv
import kagglehub

load_dotenv()

# Download latest version
path = kagglehub.competition_download('home-credit-default-risk', output_dir='./data')
print("Path to competition files:", path)