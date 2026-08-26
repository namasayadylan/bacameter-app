<?php

use Phalcon\Mvc\Controller;

/**
 * @property \PDO                              $db
 * @property \Phalcon\Http\Request              $request
 * @property \Phalcon\Http\Response              $response
 * @property \Phalcon\Session\Manager             $session
 * @property \Phalcon\Mvc\View                     $view
 */
class ControllerBase extends Controller
{
    public function beforeExecuteRoute()
    {
        if (!$this->session->has('user_id')) {
            $this->response->redirect('login');
            return false;
        }

        $this->view->setVar('currentUser', [
            'id'       => $this->session->get('user_id'),
            'username' => $this->session->get('username'),
            'nama'     => $this->session->get('nama'),
            'role'     => $this->session->get('role'),
        ]);

        $this->view->setVar('activeMenu', $this->dispatcher->getControllerName());

        return true;
    }
}