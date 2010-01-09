from django.core.management.base import NoArgsCommand
from net.aircable.utils import logger

try:
    from sensorsdk import models
except:
    from plugins.sensorsdk import models

class Command(NoArgsCommand):
    help = "Check if there are devices that hadn't reported data and generate the regarding alerts"
    
    def handle_noargs(self, **options):
	logger.info("Checking if there has been a device which hasn't reported for long period")
	models.AlertDefinition.check_nodata()
