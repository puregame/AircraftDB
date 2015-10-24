import logging

logFile="apiLog.log"
logging.basicConfig(filename=logFile, format='%(asctime)s - %(name)s\t- %(levelname)s\t- %(message)s',level=logging.DEBUG)
logger = logging.getLogger(__name__)
