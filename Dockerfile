FROM lambci/lambda:build-ruby2.7
ENV LANG C.UTF-8
ENV AWS_DEFAULT_REGION ap-northeast-1
ENV LAMBDA_PACKAGE_DIR /var/task
ENV MECAB_SOURCE_URL https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE
ENV IPADIC_SOURCE_URL https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7MWVlSDBCSXZMTXM
ENV MECAB_VERSION 0.996
ENV IPADIC_VERSION 2.7.0-20070801
ENV LIB_MECAB_DIR_NAME mecab

# WORKDIR ${LAMBDA_PACKAGE_DIR}
# RUN curl -L ${MECAB_SOURCE_URL} -o mecab.tar.gz 
# RUN curl -L ${IPADIC_SOURCE_URL} -o mecab-ipadic.tar.gz
# RUN tar -zxvf mecab.tar.gz && tar -zxvf mecab-ipadic.tar.gz

# WORKDIR ${LAMBDA_PACKAGE_DIR}/mecab-${MECAB_VERSION}
# RUN ls -al
# RUN ./configure --prefix=${LAMBDA_PACKAGE_DIR}/${LIB_MECAB_DIR_NAME} --with-charset=utf8
# RUN make && make install

# WORKDIR ${LAMBDA_PACKAGE_DIR}/mecab-ipadic-${IPADIC_VERSION}
# RUN ./configure --prefix=${LAMBDA_PACKAGE_DIR}/${LIB_MECAB_DIR_NAME} --with-charset=utf8 --with-mecab-config=${LAMBDA_PACKAGE_DIR}/${LIB_MECAB_DIR_NAME}/bin/mecab-config
# RUN make && make install

# WORKDIR ${LAMBDA_PACKAGE_DIR}
# RUN bundle install --path=vendor/bundle
# CMD zip -r ./function.zip ./*

CMD sh -c 'cd ${LAMBDA_PACKAGE_DIR} && \
    curl -L ${MECAB_SOURCE_URL} -o mecab.tar.gz && \ 
    curl -L ${IPADIC_SOURCE_URL} -o mecab-ipadic.tar.gz && \
    tar -zxvf mecab.tar.gz && tar -zxvf mecab-ipadic.tar.gz && \
    cd ${LAMBDA_PACKAGE_DIR}/mecab-${MECAB_VERSION} && \
    ./configure --prefix=${LAMBDA_PACKAGE_DIR}/${LIB_MECAB_DIR_NAME} --with-charset=utf8 && \
    make && make install && \
    cd ${LAMBDA_PACKAGE_DIR}/mecab-ipadic-${IPADIC_VERSION} && \
    ./configure --prefix=${LAMBDA_PACKAGE_DIR}/${LIB_MECAB_DIR_NAME} --with-charset=utf8 --with-mecab-config=${LAMBDA_PACKAGE_DIR}/${LIB_MECAB_DIR_NAME}/bin/mecab-config && \
    make && make install && \
    cd ${LAMBDA_PACKAGE_DIR} && \
    bundle install --path=vendor/bundle && \
    rm -f ${LAMBDA_PACKAGE_DIR}/mecab.tar.gz && \
    rm -rf ${LAMBDA_PACKAGE_DIR}/mecab-${MECAB_VERSION} && \
    rm -f ${LAMBDA_PACKAGE_DIR}/mecab-ipadic.tar.gz && \
    rm -rf ${LAMBDA_PACKAGE_DIR}/mecab-ipadic-${IPADIC_VERSION} && \
    zip -r ./function.zip ./* '