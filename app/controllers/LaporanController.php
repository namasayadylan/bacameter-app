<?php
class LaporanController extends ControllerBase
{
    public function indexAction()
    {
        $this->view->setVar('pageTitle', 'Laporan');
    }
}