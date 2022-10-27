FROM python:3.8
WORKDIR /home/usr/src/app/
COPY requirements.txt .
# COPY . .

RUN pip install -r requirements.txt

RUN python -m spacy download en_core_web_md
# make a directory for the rbp files
RUN mkdir -p /home/vivi/rbp/prp

RUN chmod -R u=rwx,g=rwx,o=rwx /home/vivi/rbp
# RUN chown root /home/vivi/rbp/prp
# USER newuser