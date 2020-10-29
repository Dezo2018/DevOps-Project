FROM python:3.7.3-stretch

# Working Directory
WORKDIR /app

COPY . app.py /app/


RUN pip install -r requirements.txt

EXPOSE 8081

CMD ["python", "app.py"]
