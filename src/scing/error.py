import logging

logger = logging.getLogger()


def raise_error(msg: str):

    logger.error(msg)
    raise Exception(msg)
