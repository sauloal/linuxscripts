<?php

/* $Id: RunningTransfer.azureus.php 2555 2007-02-09 11:19:32Z b4rt $ */

/*******************************************************************************

 LICENSE

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License (GPL)
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU General Public License for more details.

 To read the license please visit http://www.gnu.org/copyleft/gpl.html

*******************************************************************************/

/**
 * class RunningTransferAzureus for azureus-client
 */
class RunningTransferAzureus extends RunningTransfer
{

	/**
	 * ctor
	 *
	 * @param $psLine
	 * @return RunningTransferAzureus
	 */
    function RunningTransferAzureus($psLine) {
    	global $cfg;
    	$this->processId = 0;
    	$this->transferFile = "";
    	$this->filePath = $cfg['transfer_file_path'];
    	$this->transferowner = $cfg['user'];
    	$this->args = "";
    }

}

?>