<?php

class DashboardController extends ControllerBase
{
    public function indexAction()
    {
        $this->view->setVar('pageTitle', 'Dashboard');
    }
}